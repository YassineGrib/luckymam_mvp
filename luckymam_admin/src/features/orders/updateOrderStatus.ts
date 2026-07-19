import { doc, serverTimestamp, updateDoc } from 'firebase/firestore'
import { db } from '../../lib/firebase'
import { auth } from '../../lib/firebase'

/**
 * Transitions an order's status. Writes exactly the three fields the
 * firestore.rules admin-update rule allows (`status`, `statusUpdatedAt`,
 * `statusUpdatedBy`) — any other field here would be rejected server-side.
 */
export async function updateOrderStatus(
  collectionName: string,
  orderId: string,
  status: string,
) {
  await updateDoc(doc(db, collectionName, orderId), {
    status,
    statusUpdatedAt: serverTimestamp(),
    statusUpdatedBy: auth.currentUser?.uid ?? null,
  })
}
