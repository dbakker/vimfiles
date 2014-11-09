================================
Vim reStructeredText Link Plugin
================================

This vim plugin helps you manage `reference based links`_ in reStructuredText documents.

Specification
=============

The standard, *embedded*, way of creating a link using reStructeredText:

.. sourcecode:: rst

    `RFC 2396 <http://www.rfc-editor.org/rfc/rfc2396.txt>`_ and
    `RFC 2732 <http://www.rfc-editor.org/rfc/rfc2732.txt>`_ together
    define the syntax of URIs. For more information check out
    `Vim <http://www.vim.org>`_.

This format of defining links is easy to remember and write. However it is **not** easy on your eyes!

There is a better way to define them, using a *named reference*:

.. sourcecode:: rst

    `RFC 2396`_ and `RFC 2732`_ together define the syntax of URIs.
    For more information check out Vim_.

Much more readable! The matching URLs can be put at the bottom of the text:

.. sourcecode:: rst

    .. _RFC 2396: http://www.rfc-editor.org/rfc/rfc2396.txt
    .. _RFC 2732: http://www.rfc-editor.org/rfc/rfc2732.txt
    .. _Vim: http://www.vim.org

The resulting text in HTML:

  `RFC 2396`_ and `RFC 2732`_ together define the syntax of URIs.
  For more information check out Vim_.

What this plugin does
=====================

If you have your cursor on a link:

* Transform ```Foo bar <http://example.com>``\_` to ```Foo bar```\_ (this also creates a reference at the bottom of the page)
* Transform ```Foo bar```\_ back to ```Foo bar <http://example.com>``\_` (removes the reference again)
* Fetch the title of a plain hyperlink like ``http://www.dbakker.com``, turning it into
  ```Daan O. Bakker <http://www.dbakker.com>`_``.
* Open any link in your browser; ``Example_``, ```Example
  <http://example.com>``\_`, and a hyperlink like ``http://example.com`` will all work.

I built in some sanity checks to prevent problems like duplicate targets.

Mappings
========

I haven't defined any mappings, but you can do so yourself!

Put something like this in your ``.vimrc``:

.. sourcecode:: vim

    nnoremap <space>tr :<C-U>call rstlink#toggle_reference()<CR>
    nnoremap <space>wt :<C-U>call rstlink#set_web_title()<CR>
    nnoremap gl :<C-U>call rstlink#browse()<CR>

You can replace the keys before ``:<C-U>call ...`` with your own.

Installation
============

The entire plugin is currently just one file; you can install it by copying
`autoload/rstlink.vim` into your `~/.vim/autoload` folder.

An alternative example for installing with pathogen.vim_:

.. sourcecode:: sh

    cd ~/.vim/bundle
    git clone https://github.com/dbakker/vim-rstlink

You can also use a plugin manager like NeoBundle_, Vundle_ or VAM_.

Your version of Vim also needs to have ``+lua`` compiled in. I believe
this is the default for most packages except for the "tiny" ones. The
``rstlink#set_web_title()`` method also needs ``+python`` (in order to parse
HTML).

Enjoy your readable texts!

Known limitations
=================

... to be improved upon someday:

* Modifying a multiline link isn't supported, you'll have to `J` (join) first
* Links with a ` in them like this: ```Foo \`bar\` <http://example.org>`_``
  aren't correctly handled.
* Anonymous links aren't supported.
* Multiline named hyperlinks don't work.
* Little support for footnotes, citations and internal targets.

License
=======

`The MIT License`_. Copyright (c) 2014 Daan O. Bakker.

.. _reference based links: http://docutils.sourceforge.net/docs/ref/rst/restructuredtext.html#embedded-uris-and-aliases
.. _pathogen.vim: https://github.com/tpope/vim-pathogen
.. _NeoBundle: https://github.com/Shougo/neobundle.vim
.. _Vundle: https://github.com/gmarik/Vundle.vim
.. _VAM: https://github.com/MarcWeber/vim-addon-manager
.. _RFC 2396: http://www.rfc-editor.org/rfc/rfc2396.txt
.. _RFC 2732: http://www.rfc-editor.org/rfc/rfc2732.txt
.. _Vim: http://www.vim.org
.. _The MIT License: http://opensource.org/licenses/MIT
