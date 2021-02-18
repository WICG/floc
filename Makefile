SHELL=/bin/bash

local: floc.bs
	bikeshed --die-on=warning floc floc.bs floc.html

floc.html: floc.bs
	@ (HTTP_STATUS=$$(curl https://api.csswg.org/bikeshed/ \
	                       --output floc.html \
	                       --write-out "%{http_code}" \
	                       --header "Accept: text/plain, text/html" \
	                       -F die-on=warning \
	                       -F file=@floc.bs) && \
	[[ "$$HTTP_STATUS" -eq "200" ]]) || ( \
		echo ""; cat floc.html; echo ""; \
		rm -f floc.html; \
		exit 22 \
	);

remote: floc.html

ci: floc.bs
	mkdir -p out
	make remote
	mv floc.html out/index.html

clean:
	rm floc.html
