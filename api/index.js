module.exports = (req, res) => {
  // 处理不同的路径
  const { url, query } = req;

  // Vercel rewrites 将 /api/:path 转换为 /api?path=xxx
  // 所以需要从 query 中获取路径
  const rawPath = query.path || url.replace('/api', '').split('?')[0] || '';
  const path = rawPath.startsWith('/') ? rawPath : '/' + rawPath;

  if (path === '/health') {
    res.status(200).json({
      status: 'ok',
      timestamp: new Date().toISOString(),
      message: 'Health check passed'
    });
    return;
  }

  if (path === '/test') {
    res.status(200).json({
      message: 'Test endpoint working',
      timestamp: new Date().toISOString()
    });
    return;
  }

  if (path === '/' || path === '') {
    res.status(200).json({
      message: 'API is running',
      timestamp: new Date().toISOString(),
      endpoints: ['/health', '/test']
    });
    return;
  }

  // 其他路径返回 404
  res.status(404).json({
    error: 'Not found',
    path: path,
    rawPath: rawPath,
    url: url,
    query: query,
    availableEndpoints: ['/health', '/test']
  });
};
