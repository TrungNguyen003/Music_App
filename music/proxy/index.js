const express = require('express');
const cors = require('cors');
const fetch = require('node-fetch');

const app = express();
app.use(cors());
app.use(express.json()); // Để phân tích JSON body

// Bộ nhớ tạm cho người dùng (KHÔNG dùng trong sản xuất)
const users = [];
// Bộ nhớ tạm cho yêu thích: { email: [songId1, songId2] }
const favorites = {};

// API lấy danh sách yêu thích
app.get('/api/favorites/:email', (req, res) => {
  const email = req.params.email;
  res.json(favorites[email] || []);
});

// API thêm/xóa yêu thích
app.post('/api/favorites', (req, res) => {
  const { email, songId } = req.body;
  if (!favorites[email]) favorites[email] = [];
  
  const index = favorites[email].indexOf(songId);
  if (index === -1) {
    favorites[email].push(songId);
    res.json({ message: 'Đã thêm vào yêu thích', isFavorite: true });
  } else {
    favorites[email].splice(index, 1);
    res.json({ message: 'Đã xóa khỏi yêu thích', isFavorite: false });
  }
});

// API Đăng ký
app.post('/api/register', (req, res) => {
  try {
    const { email, password } = req.body;
    
    if (!email || !password) {
      return res.status(400).json({ error: 'Email và mật khẩu không được để trống' });
    }
    
    if (users.find(u => u.email === email)) {
      return res.status(400).json({ error: 'Email đã tồn tại' });
    }
    
    users.push({ email, password });
    return res.status(200).json({ message: 'Đăng ký thành công' });
  } catch (error) {
    console.error('Register error:', error);
    res.status(500).json({ error: 'Lỗi server' });
  }
});

// API Đăng nhập
app.post('/api/login', (req, res) => {
  const { email, password } = req.body;
  const user = users.find(u => u.email === email && u.password === password);
  if (!user) {
    return res.status(401).json({ error: 'Email hoặc mật khẩu không đúng' });
  }
  res.json({ message: 'Đăng nhập thành công', user: { email } });
});

app.get('/api/songs', async (req, res) => {
  try {
    const response = await fetch('https://thantrieu.com/resources/braniumapis/songs.json');
    const data = await response.json();
    res.json(data);
  } catch (error) {
    console.error('Proxy error:', error);
    res.status(500).json({ error: error.message });
  }
});

app.get('/api/image', async (req, res) => {
  try {
    const imageUrl = req.query.url;
    if (!imageUrl) {
      return res.status(400).json({ error: 'URL parameter required' });
    }
    
    const response = await fetch(imageUrl);
    res.set('Content-Type', response.headers.get('content-type'));
    res.set('Cache-Control', 'public, max-age=86400');
    response.body.pipe(res);
  } catch (error) {
    console.error('Image proxy error:', error);
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Proxy running on port ${PORT}`));
