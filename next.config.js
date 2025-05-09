/** @type {import('next').NextConfig} */

const nextConfig = {
  output: 'export',
  
  // Configure for custom domain on GitHub Pages
  basePath: '',
  assetPrefix: '',
  
  // Image optimization settings
  images: {
    unoptimized: true, // Required for static export
  },
  
  // Used to ensure proper file structure for GitHub Pages
  trailingSlash: true,
  
  // Optimization settings
  swcMinify: true, // Use SWC minifier for better performance
  
  // Remove console logs in production
  compiler: {
    removeConsole: process.env.NODE_ENV === 'production' ? {
      exclude: ['error', 'warn'],
    } : false,
  },
  
  // Performance and accessibility improvements
  reactStrictMode: true,
};

module.exports = nextConfig; 