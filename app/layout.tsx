export const metadata = { title: 'CloudCurio.cc', description: 'Curate, Compute, Create.' };
export default function RootLayout({ children }: { children: React.ReactNode }){
  return (
    <html lang="en">
      <body>{children}</body>
    </html>
  )
}
