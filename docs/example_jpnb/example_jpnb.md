# Hello World document

The documentation can be atuomatically generate starting from a jupyter notebook. In this case the jupyter environment is called with the module nbconvert that convert the ipynb file into the md text. Please ensure that you have the nbconvert template file in the jupyter data_dir.



```python
# a block of python code can be tested and documented from the same file.

import sys,os
```

For example this code fragment shows the exported environment used by Makefile during setup.



```python
print(os.environ['srcdir'])
print(os.environ['top_srcdir'])
print(os.environ['abs_top_srcdir'])
print(os.environ['builddir'])
print(os.environ['top_builddir'])
print(os.environ['abs_top_builddir'])
```

    .
    ../..
    /home/rigoni/autoconf-bootstrap
    .
    ../..
    /home/rigoni/autoconf-bootstrap


## example of embedded formula

$$ E = m \cdot c^2 $$


```math
E = m c^2
```

## example of embedded image

![](img/book_cover.jpg)
