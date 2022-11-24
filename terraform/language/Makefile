slides.html: slides.md
	pandoc -s --mathjax -i -t revealjs -V theme=league -o $@ $<

clean:
	rm -f *.html

.PHONY: presentation.html
