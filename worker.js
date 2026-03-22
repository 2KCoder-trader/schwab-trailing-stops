export default {
  async fetch(request, env) {
    const url = new URL(request.url);

    if (request.method === 'POST' && url.pathname === '/api/token') {
      return handleTokenExchange(request, env);
    }

    if (request.method === 'POST' && url.pathname === '/api/refresh') {
      return handleTokenRefresh(request, env);
    }

    // Fall through to static assets
    return fetch(request);
  }
};

async function handleTokenExchange(request, env) {
  const { code } = await request.json();
  if (!code) return jsonError('missing code', 400);

  const credentials = btoa(`${env.APP_KEY}:${env.APP_SECRET}`);
  const response = await fetch('https://api.schwabapi.com/v1/oauth/token', {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${credentials}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: `grant_type=authorization_code&code=${encodeURIComponent(code)}&redirect_uri=${encodeURIComponent('https://trade.dataflexlab.com')}`,
  });

  const data = await response.json();
  return new Response(JSON.stringify(data), {
    status: response.status,
    headers: { 'Content-Type': 'application/json' },
  });
}

async function handleTokenRefresh(request, env) {
  const { refresh_token } = await request.json();
  if (!refresh_token) return jsonError('missing refresh_token', 400);

  const credentials = btoa(`${env.APP_KEY}:${env.APP_SECRET}`);
  const response = await fetch('https://api.schwabapi.com/v1/oauth/token', {
    method: 'POST',
    headers: {
      'Authorization': `Basic ${credentials}`,
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body: `grant_type=refresh_token&refresh_token=${encodeURIComponent(refresh_token)}`,
  });

  const data = await response.json();
  return new Response(JSON.stringify(data), {
    status: response.status,
    headers: { 'Content-Type': 'application/json' },
  });
}

function jsonError(message, status) {
  return new Response(JSON.stringify({ error: message }), {
    status,
    headers: { 'Content-Type': 'application/json' },
  });
}
