# Hello World document


```python
import sys,os
```

This doument shows the environment used by makefile during setup.



```python
print(os.environ['srcdir'])
print(os.environ['top_srcdir'])
print(os.environ['abs_top_srcdir'])
print(os.environ['builddir'])
print(os.environ['top_builddir'])
print(os.environ['abs_top_builddir'])
```

    ../../../src/jp_notebook
    ../../..
    /home/andrea/devel/utils/autoconf-bootstrap/build/..
    .
    ../..
    /home/andrea/devel/utils/autoconf-bootstrap/build


## example of embedded image

![](img/book_cover.jpg)

## example of embedded formula

$$ E = m \cdot c^2 $$
