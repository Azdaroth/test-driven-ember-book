#!/bin/bash
pandoc --epub-metadata=metadata.xml --toc --toc-depth=2 --highlight-style pygments -S -o  test-driven-ember.epub title.txt \
  000_front_page.markdown \
  002_dedication_and_copyrights.markdown \
  003_preface.markdown \
  010-introduction/introduction.markdown \
  020-testing/testing.markdown \
  030-essential-tools/essential-tools.markdown \
  040-test-driving-application/test-driving-application.markdown \
  050-closing-thoughts/closing-thoughts.markdown

pandoc --epub-metadata=metadata.xml --toc --toc-depth=2 --highlight-style pygments -S -o  test-driven-ember.pdf title.txt \
  000_front_page.markdown \
  002_dedication_and_copyrights.markdown \
  003_preface.markdown \
  010-introduction/introduction.markdown \
  020-testing/testing.markdown \
  030-essential-tools/essential-tools.markdown \
  040-test-driving-application/test-driving-application.markdown \
  050-closing-thoughts/closing-thoughts.markdown

pandoc --epub-metadata=metadata.xml --toc --toc-depth=2 --highlight-style pygments -S -o  test-driven-ember.html title.txt \
  000_front_page.markdown \
  002_dedication_and_copyrights.markdown \
  003_preface.markdown \
  010-introduction/introduction.markdown \
  020-testing/testing.markdown \
  030-essential-tools/essential-tools.markdown \
  040-test-driving-application/test-driving-application.markdown \
  050-closing-thoughts/closing-thoughts.markdown

kindlegen test-driven-ember.epub
