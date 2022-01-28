ls | sed -n 's/\(.*\)\.jpg\(.*\)/mv "\1\.jpg\2" "\1\.jpg"/p' | sh
ls | sed -n 's/\(.*\)\.webp\(.*\)/mv "\1\.webp\2" "\1\.jpg"/p' | sh