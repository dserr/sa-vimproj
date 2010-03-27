" def addSandboxTags {{{
python <<EOF
import sys
import os
from os import path

if sys.platform == 'linux2':
    sys.path += ['/home/savadhan/vim']
else:
    sys.path += [r'\\mathworks\home\savadhan\vim']

try:
    from getProjSettings import getProjSettings
    from pathUtils import getRootDir

    def addSandboxTags(fname):
        rootDir = getRootDir()
        soln = getProjSettings()
        if not soln:
            return

        for proj in soln.projects:
            if proj.includesFile(fname):
                # add project tags
                for inc in proj.includes:
                    vim.command('let &l:tags .= ",%s"' % path.join(rootDir, inc['path'], inc['tagsFile']))

                # add imported header tags.
                for dep in proj.depends:
                    dep_proj = soln.getProjByName(dep)
                    for inc in dep_proj.exports:
                        vim.command('let &l:tags .= ",%s"' % path.join(rootDir, inc['path'], inc['tagsFile']))
                    

except ImportError:
    def addSandboxTags(fname):
        pass

    pass
EOF
" }}}

let s:path = expand('<sfile>:p:h')
" mw#tag#AddSandboxTags: add all tags for a given C/C++ file {{{
function! mw#tag#AddSandboxTags(fname)
    let &l:tags = s:.path.'/cpp_std.tags'
    exec 'python addSandboxTags("'.a:fname.'")'
endfunction " }}}
" mw#tag#InitVimTags:  {{{
" Description: 
function! mw#tag#InitVimTags()
    !genVimTags.py
    call mw#tag#AddSandboxTags(expand('%:p'))
endfunction " }}}
