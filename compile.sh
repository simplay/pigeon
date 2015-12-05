echo 'Compiling Pigeon...'
rawr install
cp pigeon.rb start.rb
echo "config = ServerConfig.new" >> start.rb
echo "Bot.new(config, 'Sir Pigeon').start" >> start.rb
rake rawr:jar
rm start.rb
mkdir build/lib
cp package/jar/pigeon.jar build/
cp -r lib build/
cp -r data build/
rm build/data/*.pstore
cp LICENSE build/
cp README.md build/
rm build/data/pigeon_config.yml
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
