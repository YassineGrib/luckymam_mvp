import { useEffect, useState } from 'react'
import { collection, onSnapshot, orderBy, query } from 'firebase/firestore'
import { db } from '../../lib/firebase'
import type { BaseOrder } from '../../lib/orderTypes'

/**
 * Live-subscribes to every document in an order-like top-level collection
 * (print_orders / album_claims / marketplace_orders), newest first.
 * No userId filter — admins see everyone's orders, gated by firestore.rules'
 * isAdmin() on the read side.
 */
export function useOrderQueue<T extends BaseOrder>(collectionName: string) {
  const [orders, setOrders] = useState<T[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    const q = query(collection(db, collectionName), orderBy('createdAt', 'desc'))
    const unsubscribe = onSnapshot(
      q,
      (snapshot) => {
        setOrders(
          snapshot.docs.map((d) => ({ id: d.id, ...d.data() }) as T),
        )
        setLoading(false)
        setError(null)
      },
      (err) => {
        setError(err.message)
        setLoading(false)
      },
    )
    return unsubscribe
  }, [collectionName])

  return { orders, loading, error }
}
