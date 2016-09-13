# Maintainer: XZS <d dot f dot fischer at web dot de>
pkgname=hardsub-git
pkgver=r0
pkgrel=1
pkgdesc="burn soft subtitles into video"
arch=('any')
url="https://github.com/dffischer/hardsub"
license=('GPL')
depends=('ffmpeg' 'grep')
makedepends=('ruby-ronn')

# template input; name=git

build() {
  cd "$_gitname"
  sed 's|\(FONTCONFIG_FILE="\).*\(/fonts.conf"\)|\1/usr/share/'"$pkgname"'\2|' \
    -i hardsub.sh
  ronn --roff *.md
}

package() {
  cd "$_gitname"
  install -D hardsub.sh "$pkgdir/usr/bin/hardsub"
  install -D -t "$pkgdir/usr/share/$pkgname" fonts.conf
  install -Dm644 -t "$pkgdir/usr/share/man/man1" *.1
}
