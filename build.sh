#!/usr/bin/env sh

# Get the absolute path to the bash script
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Remove old versions
for file in LastResortPrivate*-Regular.otf LastResortPrivate*-Regular.ttf
do
    if [[ -f $file ]]
    then
	rm $file
	echo "Removed $file"
    fi
done

# Build FORMAT 13 (Last Resort Private High-Efficiency; LastResortPrivateHE-Regular.ttf)

# Build a temporary name-keyed OpenType/CFF font (OTF)
makeotf -r -nS -nshw -overrideMenuNames -f font.ufo -ff features.fea -omitMacNames -omitDSIG -gf GlyphOrderAndAliasDB -o LastResortPrivateHE-Regular.otf

# Convert the OTF to TTF
otf2ttf -o temp.ttf LastResortPrivateHE-Regular.otf

# Replace the 'cmap' table with one that includes a Format 13 subtable
ttx -m temp.ttf -o temp2.ttf cmap-f13.ttx

# Replace the 'OS/2' and 'head' tables
ttx -m temp2.ttf -o LastResortPrivateHE-Regular.ttf tables.ttx

# Clean up
rm LastResortPrivateHE-Regular.otf temp.ttf temp2.ttf

# Build FORMAT 12 (Last Resort Private; LastResortPrivate-Regular.ttf)

# The "lastresort13to12.py" script converts the Format 13 'cmap' subtable
# to a Format 12 subtable, and generates an AFDKO "mergefonts" mapping file
# that creates 16 duplicates of each glyph for more efficient range
# mappings, along with a "GlyphOrderAndAliasDB2" file for use with AFKDO
# "makeotf"

python3 scripts/lastresort13to12.py cmap-f13.ttx
mergefonts font2.ufo mergefonts.map font.ufo
sed -i "" "s/LastResortPrivateHE-Regular/LastResortPrivate-Regular/g ; s/Last Resort Private High-Efficiency/Last Resort Private/g" font2.ufo/fontinfo.plist
sed "s/ High-Efficiency//g" < features.fea > features2.fea

# Build a temporary name-keyed OpenType/CFF font (OTF)
makeotf -r -nS -nshw -overrideMenuNames -f font2.ufo -ff features2.fea -omitMacNames -omitDSIG -gf GlyphOrderAndAliasDB2 -o LastResortPrivate-Regular.otf

# Convert the OTF to TTF
otf2ttf -o temp.ttf LastResortPrivate-Regular.otf

# Replace the 'cmap' table with one that includes a Format 12 subtable
ttx -m temp.ttf -o temp2.ttf cmap-f12.ttx

# Replace the 'OS/2' and 'head' tables
ttx -m temp2.ttf -o LastResortPrivate-Regular.ttf tables.ttx

# Clean up
rm LastResortPrivate-Regular.otf temp.ttf temp2.ttf GlyphOrderAndAliasDB2 cmap-f12.ttx features2.fea mergefonts.map
rm -rf font2.ufo

# EOF
