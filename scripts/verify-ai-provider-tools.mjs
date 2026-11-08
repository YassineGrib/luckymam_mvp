// Tests real provider tool round-trips using synthetic context only.
import { spawnSync } from 'node:child_process';
import { handleChat } from '../functions/ai/handler.mjs';
import { generate } from '../functions/ai/gemini.mjs';
import { createMakeTools } from '../functions/ai/tools.mjs';

const result = spawnSync(process.execPath, [process.env.LUCKYMAM_FIREBASE_ENTRY,
  'functions:secrets:access', 'GEMINI_API_KEY', '--project', 'luckymam-app-dv'],
{ encoding: 'utf8', timeout: 60000, env: { ...process.env, CI: 'true' } });
const apiKey = result.stdout?.match(/(?:AQ\.|AIza)[\w-]{20,}/)?.[0];
if (!apiKey) {
  console.log(JSON.stringify({ stage: 'secret-access', hasKey: false, exitCode: result.status }));
  process.exit(1);
}
let toolCalls = 0;
const factory = createMakeTools({ db: null });
const makeTools = (args) => {
  const tools = factory(args);
  return { ...tools, execute: async (...parameters) => {
    toolCalls++;
    return tools.execute(...parameters);
  } };
};
const diagnosticFetch = async (...args) => {
  const response = await fetch(...args);
  if (!response.ok) {
    const error = (await response.clone().json().catch(() => ({}))).error;
    console.log(JSON.stringify({ stage: 'provider', status: response.status,
      error: error?.status,
      reason: error?.message?.replace(/(?:AQ\.|AIza)[\w-]+/g, '[REDACTED]').slice(0, 240) }));
  }
  return response;
};
try {
  const reply = await handleChat({
    uid: 'synthetic-tool-diagnostic',
    message: 'Please call get_family_context first, then greet me briefly.',
    locale: 'fr', history: [],
    deps: { apiKey, db: null, loadContext: async () => ({ stage: 'E', children: [] }),
      makeTools, generate: (args) => generate({ ...args, fetchImpl: diagnosticFetch }) },
  });
  const passed = toolCalls > 0 && !!reply.reply?.trim();
  console.log(JSON.stringify({ stage: 'result', passed, toolCalls, replyLength: reply.reply?.length }));
  if (!passed) process.exitCode = 1;
} catch (error) {
  console.log(JSON.stringify({ stage: 'result', passed: false, toolCalls, code: error.code, type: error.name }));
  process.exitCode = 1;
}
