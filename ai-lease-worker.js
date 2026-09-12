const DEFAULT_SYSTEM_PROMPT = `You are Mushavo Homes' lease drafting assistant. Create a clear, professional lease agreement draft from the supplied structured details. Do not claim to be a lawyer. Include a short review note that the landlord should check local law before signing. Keep the draft practical and organized with numbered sections.`;

function json(data, status = 200, origin = '*') {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      'Content-Type': 'application/json',
      'Access-Control-Allow-Origin': origin,
      'Access-Control-Allow-Methods': 'POST, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type'
    }
  });
}

function buildPrompt(body) {
  const lease = body?.lease || {};
  const options = body?.options || {};
  return [
    'Draft a lease agreement using these details.',
    '',
    'Lease details:',
    JSON.stringify(lease, null, 2),
    '',
    'Landlord selected options and clauses:',
    JSON.stringify(options, null, 2),
    '',
    'Requirements:',
    '- Use plain, professional language.',
    '- Include parties, premises, lease term, rent, deposit, utilities, maintenance, rules, notices, additional terms, and signature lines.',
    '- If something is missing, write "To be confirmed" instead of inventing facts.',
    '- Do not include unsafe or unfair clauses.',
    '- End with a short note to review against local law before signing.'
  ].join('\n');
}

function extractDraft(providerResult) {
  return providerResult?.choices?.[0]?.message?.content
    || providerResult?.choices?.[0]?.text
    || providerResult?.output_text
    || providerResult?.response
    || providerResult?.text
    || '';
}

export default {
  async fetch(request, env) {
    const origin = env.ALLOWED_ORIGIN || '*';

    if (request.method === 'OPTIONS') {
      return json({}, 204, origin);
    }

    if (request.method !== 'POST') {
      return json({ error: 'Method not allowed.' }, 405, origin);
    }

    if (!env.AI_API_KEY || !env.AI_API_URL) {
      return json({ error: 'AI lease service is not configured yet.' }, 500, origin);
    }

    let body;
    try {
      body = await request.json();
    } catch (error) {
      return json({ error: 'Invalid request body.' }, 400, origin);
    }

    const prompt = buildPrompt(body);
    const upstream = await fetch(env.AI_API_URL, {
      method: 'POST',
      headers: {
        'Authorization': `Bearer ${env.AI_API_KEY}`,
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({
        model: env.AI_MODEL || 'gpt-4o-mini',
        messages: [
          { role: 'system', content: env.AI_SYSTEM_PROMPT || DEFAULT_SYSTEM_PROMPT },
          { role: 'user', content: prompt }
        ],
        temperature: 0.2
      })
    });

    const providerResult = await upstream.json().catch(() => ({}));
    if (!upstream.ok) {
      return json({
        error: providerResult?.error?.message || providerResult?.message || 'AI provider request failed.'
      }, upstream.status, origin);
    }

    const draft = extractDraft(providerResult).trim();
    if (!draft) {
      return json({ error: 'AI provider did not return a lease draft.' }, 502, origin);
    }

    return json({ draft }, 200, origin);
  }
};
