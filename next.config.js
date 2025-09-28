/** @type {import('next').NextConfig} */
const nextConfig = { 
  // Remove output: 'export' to allow for server functions in Cloudflare Pages
  trailingSlash: true,
  images: {
    unoptimized: true
  }
};

export default nextConfig;
