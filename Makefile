test:
	docker run -it --rm -v "$(shell pwd):/src" shellspec/shellspec
