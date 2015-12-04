echo 'Compiling Pigeon...'
rawr install
rake rawr:jar
mkdir build/lib
cp package/jar/pigeon.jar build/
cp -r lib build/
cp -r data build/
rm build/data/*.pstore
cp LICENSE build/
cp README.md build/
echo 'Compiled pigeon.jar to build/'
zip -r build/pigeon.zip build/
rm build/pigeon.jar
rm -rf build/lib
rm -rf build/data
rm build/LICENSE
rm build/README.md
rm build/start.rb
rm -rf package/
rm -rf src/org/
