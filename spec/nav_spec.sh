Describe 'Missing arguments.'
  Include nav.sh

  It 'calls "nav add" without a shortcut'
    When call nav add
    The of output should equal 'Please provide a shortcut and a directory.
usage: nav add <shortcut> <directory>

Add a new shortcut to the provided directory.'
    The status should be failure
  End

  It "calls "nav add" without a directory"
    When call nav add foo
    The output should equal 'Please provide a shortcut and a directory.
usage: nav add <shortcut> <directory>

Add a new shortcut to the provided directory.'
    The status should be failure
  End

  It 'calls "nav to" without a shortcut'
    When call nav to
    The output should equal 'Please provide a shortcut.
usage: nav to <shortcut>

Navigate to the directory under the provided shortcut.'
    The status should be failure
  End

  It 'calls "nav update" without a shortcut'
    When call nav update
    The output should equal 'not implemented'
    The status should be failure
  End

  It 'calls "nav update" without a directory'
    When call nav update foo
    The output should equal 'not implemented'
    The status should be failure
  End

  It 'calls "nav remove" without a shortcut'
    When call nav remove
    The output should equal 'Please provide a shortcut.
usage: nav remove <shortcut>

Remove an existing shortcut.'
    The status should be failure
  End
End

Describe 'No existing shortcuts.'
  Include nav.sh

  setup() {
    starting_dir="$(pwd)"
    mkdir -p ~/tmp/real-dir
    ln -s ~/tmp/real-dir ~/tmp/symlinked-dir
  }

  cleanup() {
    rm -rf ~/tmp
    rm -rf ~/.config/nav
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  It 'adds a shortcut to a non-existing directory'
    When call nav add foo ~/tmp/fake-dir
    The status should be failure
    The output should equal 'Error: /root/tmp/fake-dir is not a directory.'
    The dir "$(pwd)" should equal "$starting_dir"
  End

  It 'adds a shortcut to a real directory'
    When call nav add foo ~/tmp/real-dir
    The status should be success
    The output should equal 'Added a shortcut from foo to /root/tmp/real-dir!'
    The path ~/.config/nav/foo should be symlink
    The dir "$(pwd)" should equal "$starting_dir"
  End

  It 'adds a shortcut to a symlinked directory'
    When call nav add foo ~/tmp/symlinked-dir
    The status should be success
    The output should equal 'Added a shortcut from foo to /root/tmp/real-dir!'
    The path ~/.config/nav/foo should be symlink
    The dir "$(pwd)" should equal "$starting_dir"
  End

  It 'lists no shortcuts'
    When call nav list
    The status should be success
    The output should equal ''
    The dir "$(pwd)" should equal "$starting_dir"
  End
End

Describe 'Interacting with existing shortcuts.'
  Include nav.sh

  setup() {
    starting_dir="$(pwd)"
    mkdir -p ~/tmp/real-dir
    ln -s ~/tmp/real-dir ~/tmp/symlinked-dir
    nav add foo ~/tmp/real-dir
    nav add bar ~/tmp/symlinked-dir
    nav add baz .
  }

  cleanup() {
    rm -rf ~/tmp
    rm -rf ~/.config/nav
  }

  BeforeEach 'setup'
  AfterEach 'cleanup'

  It 'navigates to a fake shortcut'
    When call nav to bad
    The status should be failure
    The output should equal "Shortcut 'bad' not found."
    The dir "$(pwd)" should equal "$starting_dir"
  End

  It 'navigates to a shortcut to a real directory'
    When call nav to foo
    The status should be success
    The output should equal ''
    The dir "$(pwd)" should not equal "$starting_dir"
    The dir "$(pwd)" should equal "/root/tmp/real-dir"
  End

  It 'navigates to a shortcut to a symlinked directory'
    When call nav to bar
    The status should be success
    The output should equal ''
    The dir "$(pwd)" should not equal "$starting_dir"
    The dir "$(pwd)" should equal "/root/tmp/real-dir"
  End

  It 'navigates to a shortcut to a current directory'
    When call nav to baz
    The status should be success
    The output should equal ''
    The dir "$(pwd)" should equal "$starting_dir"
  End

  It 'updates a shortcut'
    # TODO: need to figure out if update means to update or rename
    When call nav update foo placeholder
    The output should equal 'not implemented'
    The status should be failure
    The dir "$(pwd)" should equal "$starting_dir"
  End

  It 'removes a fake shortcut'
    When call nav remove bad
    The status should be failure
    The output should equal 'bad is not a shortcut.'
    The dir "$(pwd)" should equal "$starting_dir"
  End

  It 'removes a shortcut'
    When call nav remove foo
    The status should be success
    The output should equal ''
    The path ~/.config/nav/foo should not exist
    The dir "$(pwd)" should equal "$starting_dir"
  End
End
