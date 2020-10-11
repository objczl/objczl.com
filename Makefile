install:
	@bundle exec jekyll serve --watch --draft
clean:
	@rm -rf _site
release:
	@JEKYLL_ENV=production jekyll build
update:
	@bundle update
	@bundle install

