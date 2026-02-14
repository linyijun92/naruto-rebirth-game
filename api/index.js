module.exports = (req, res) => {
  // 处理不同的路径
  const { url } = req;

  if (url === '/api/health' || url === '/health') {
    res.status(200).json({
      status: 'ok',
      timestamp: new Date().toISOString(),
      message: 'Health check passed'
    });
    return;
  }

  if (url === '/api/test' || url === '/test') {
    res.status(200).json({
      message: 'Test endpoint working',
      timestamp: new Date().toISOString()
    });
    return;
  }

  if (url === '/api' || url === '/') {
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
    url: url,
    availableEndpoints: ['/health', '/test']
  });
};
