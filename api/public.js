module.exports = (req, res) => {
  const { url } = req;

  // 返回欢迎页面
  if (url === '/' || url === '') {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    const fs = require('fs');
    const html = fs.readFileSync(__dirname + '/../public/index.html', 'utf8');
    res.end(html);
    return;
  }

  // 返回 favicon
  if (url === '/favicon.ico' || url === '/favicon.png') {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'image/x-icon');
    res.end('');
    return;
  }

  // 404
  res.statusCode = 404;
  res.setHeader('Content-Type', 'application/json');
  res.end(JSON.stringify({
    error: 'Not found',
    url: url
  }));
};
