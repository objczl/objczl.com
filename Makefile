clean:
	@rm -rf _site
install:
	@bundle exec jekyll serve --watch --draft
release:
	@JEKYLL_ENV=production jekyll build
update:
	@bundle update
	@bundle install

