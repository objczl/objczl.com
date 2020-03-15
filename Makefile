clean:
	@rm -rf _site
install:
	@bundle exec jekyll serve --watch --draft
update:
	@bundle update
	@bundle install

