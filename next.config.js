/** @type {import('next').NextConfig} */
const nextConfig = { 
  experimental: { 
    serverActions: true 
  },
  output: 'export',
  trailingSlash: true,
  images: {
    unoptimized: true
  }
};

export default nextConfig;
