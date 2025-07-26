export default function handler(req, res) {
  const redirectUrl = `https://accounts.google.com/oauth/authorize?client_id=${process.env.GOOGLE_CLIENT_ID}&redirect_uri=${process.env.VERCEL_URL}/api/auth/google/callback&scope=openid%20profile%20email&response_type=code`;
  
  res.redirect(302, redirectUrl);
}