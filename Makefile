
default: manual-build build

manual-build: web/css/index.css web/index.html web/online.html web/ace

heroku: get-globals default make-online

make-online:
	@mv web/online.html web/index.html

get-globals:
	npm install -g component jade stylus

web/css/index.css: styl/index.styl
	@stylus < styl/index.styl > web/css/index.css

web/online.html: jade/online.jade jade/*.jade
	@jade jade/online.jade -o web

web/index.html: jade/index.jade jade/*.jade
	@jade jade/index.jade -o web

web/ace:
	@mkdir -p tmp-ace;\
		cd tmp-ace;\
	    wget https://github.com/ajaxorg/ace-builds/archive/master.zip;\
	    unzip master.zip;\
	    mv ace-builds-master/src-noconflict ../web/ace;\
	    cd ..;\
	    rm -rf tmp-ace

TPLS := $(patsubst client/tpl/%.txt,client/tpl/%.txt.js,$(wildcard client/tpl/*.txt))

client/tpl/%.txt.js: client/tpl/%.txt
	@component convert $<

build: components client/index.js $(TPLS)
	@component build --dev -n index -o web/js

serve:
	@node server.js

serve-static:
	@cd web; python -m SimpleHTTPServer

components: component.json
	@component install --dev

clean:
	rm -fr build components template.js

lint:
	@jshint --verbose *.json client lib *.js test

gh-pages: default
	@rm -rf w
	@cp -r web w
	@git co gh-pages
	@rm -rf css js ace index.html online.html bootstrap
	@mv w/* ./
	@rm -rf w

.PHONY: clean lint test serve serve-static heroku make-online
