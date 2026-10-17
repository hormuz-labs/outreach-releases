#!/usr/bin/env bash
# Build Outreach's signed apt repository, served by GitHub Pages at apt.guahva.com (DNS: a GoDaddy CNAME to
# hormuz-labs.github.io). GitHub Pages can't redirect, so the release's .deb files are part of the site.
#   scripts/apt-repo.sh <dir with .deb files, may be empty> <out dir> <gpg key id> <release tag or "">
set -eu
DEBS=$1
OUT=$2
KEY=$3
TAG=$4
APT_URL=${APT_URL:-https://apt.guahva.com}
rm -rf "$OUT" && mkdir -p "$OUT"
cd "$OUT"
if ls "$DEBS"/*.deb >/dev/null 2>&1; then
  mkdir -p "pool/$TAG"
  cp "$DEBS"/*.deb "pool/$TAG/"
fi
for arch in amd64 arm64; do
  mkdir -p "dists/stable/main/binary-$arch"
  if [ -d pool ]; then apt-ftparchive --arch "$arch" packages pool > "dists/stable/main/binary-$arch/Packages"
  else : > "dists/stable/main/binary-$arch/Packages"; fi
  gzip -9fk "dists/stable/main/binary-$arch/Packages"
done
apt-ftparchive \
  -o APT::FTPArchive::Release::Origin="Hormuz Labs" \
  -o APT::FTPArchive::Release::Label="Outreach" \
  -o APT::FTPArchive::Release::Suite="stable" \
  -o APT::FTPArchive::Release::Codename="stable" \
  -o APT::FTPArchive::Release::Architectures="amd64 arm64" \
  -o APT::FTPArchive::Release::Components="main" \
  release dists/stable > ../Release.tmp   # written outside dists/stable so the Release file does not list itself
mv ../Release.tmp dists/stable/Release
gpg --batch --yes --default-key "$KEY" --clearsign -o dists/stable/InRelease dists/stable/Release
gpg --batch --yes --default-key "$KEY" -abs -o dists/stable/Release.gpg dists/stable/Release
gpg --batch --yes --armor --export "$KEY" > outreach.gpg
touch .nojekyll
if [ -n "$TAG" ]; then STATUS="Current release: $TAG."; else STATUS="The first release has not been published yet."; fi
cat > index.html <<HTML
<!doctype html><meta charset="utf-8"><title>Outreach apt repository</title>
<body style="font:16px/1.5 system-ui;max-width:46rem;margin:3rem auto;padding:0 1rem">
<h1>Outreach apt repository</h1>
<p>$STATUS Add it once and apt keeps Outreach up to date:</p>
<pre style="white-space:pre-wrap">curl -fsSL $APT_URL/outreach.gpg | sudo gpg --batch --yes --dearmor -o /usr/share/keyrings/outreach.gpg &amp;&amp;
echo "deb [signed-by=/usr/share/keyrings/outreach.gpg] $APT_URL stable main" | sudo tee /etc/apt/sources.list.d/outreach.list &amp;&amp;
sudo apt update &amp;&amp; sudo apt install outreach</pre>
<p><a href="https://github.com/hormuz-labs/outreach-releases">Outreach releases on GitHub</a></p>
HTML
echo "apt repository ${TAG:-(no release yet)} ready in $OUT"
