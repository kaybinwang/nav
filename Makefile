test:
	docker run --rm -v "$(shell pwd):/src" shellspec/shellspec
