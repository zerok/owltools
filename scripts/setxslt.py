#!/usr/bin/env python
"""
Tiny script for setting the XSLT-stylesheet of an XML file. Requires at least
one argument. The last given argument is the URL of the stylesheet and 
everything before that will be treated as a file to set the stylesheet on.

If you only pass one argument (the stylesheet) the script will read from
stdin and write to stdout.
"""
import sys, re, tempfile, shutil

class Handler(object):
    in_preamble = False
    re_style = re.compile('href="[^"]+"')
    def __call__(self, input, output, style):
        line = input.readline()
        if line is None:
            return False
        elif line.startswith("<?xml "):
            self.in_preamble=True
        elif self.in_preamble and len(line.lstrip().rstrip()) == 0:
            return True
        elif self.in_preamble and line.startswith("<?xml-stylesheet "):
            line = re.sub(self.re_style, 'href="%s"'%(style,), line)
            self.in_preamble = False
        elif self.in_preamble:
            print >>output, '<?xml-stylesheet href="%s" type="text/xsl" media="screen"?>' % (style,)
            self.in_preamble=False
        output.write(line)
        return line

if __name__ == '__main__':
    if len(sys.argv) == 0:
        print >>sys.stderr, "No arguments given."
        sys.exit(1)
    args = sys.argv[1:]
    style = args.pop()
    handle = Handler()
    
    if len(args):
        for file_ in args:
            input_ = open(file_, 'r')
            output_ = tempfile.NamedTemporaryFile(delete=False)
            try:
                while True:
                    if not handle(input_, output_, style):
                        break
                output_.close()
            except:
                output_.close()
                os.unlink(output_.name)
            input_.close()
            shutil.move(output_.name, file_)
    else:
        while True:
            if not handle(sys.stdin, sys.stdout, style):
                break
