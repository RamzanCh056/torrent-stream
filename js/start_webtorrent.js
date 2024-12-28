const WebTorrent = require('webtorrent');
const client = new WebTorrent();

const magnetLink = process.argv[2]; // Get magnet link from command-line arguments

if (!magnetLink) {
  console.error('Please provide a magnet link as an argument.');
  process.exit(1);
}

client.add(magnetLink, { path: './downloads' }, (torrent) => {
  console.log(`Downloading: ${torrent.name}`);
  const server = torrent.createServer();
  server.listen(8000); // Start HTTP server at port 8000

  console.log(`Server running at: http://localhost:8000/${encodeURIComponent(torrent.name)}`);
  torrent.on('done', () => {
    console.log('Download complete');
  });
});
