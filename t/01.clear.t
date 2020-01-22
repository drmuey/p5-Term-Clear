use Test::Spec;

our @qx_calls;
our @qx_ret = ("CLEAR SEQUENCE $^O $$\n");
our $current_qx = sub { push @qx_calls, [@_]; return @qx_ret > 1 ? @qx_ret : $qx_ret[0] };
use Test::Mock::Cmd qx => sub { $current_qx->(@_) };

use Term::Clear;

describe "Term::Clear" => sub {
    around {
        local @qx_calls                = ();
        local $Term::Clear::_clear_str = undef;
        local $Term::Clear::POSIX      = 0;

        yield;
    };

    describe "imports" => sub {
        it "should enable POSIX when given the string POSIX" => sub {
            Term::Clear->import("POSIX");
            is $Term::Clear::POSIX, 1;
        };

        it "should not enable POSIX by default" => sub {
            Term::Clear->import();
            is $Term::Clear::POSIX, 0;
        };
    };

    describe "system command fallbacks" => sub {
        it "should call the right thing under Windows" => sub {
            local $^O = "MSWin32";
            Term::Clear::_get_from_system_call();
            is_deeply \@qx_calls, [ ["cls"] ];
        };

        it "should call the right thing under non-Windows" => sub {
            local $^O = "not-windows";
            Term::Clear::_get_from_system_call();
            is_deeply \@qx_calls, [ ["/usr/bin/clear"] ];
        };
    };

    describe "\b’s clear() function" => sub {
        it "should memoize itself - variable set" => sub {
            trap { Term::Clear::clear() };
            is $trap->stdout, $Term::Clear::_clear_str;
        };

        it "should memoize itself - variable used" => sub {
            local $Term::Clear::_clear_str = "I am cached $$";
            no warnings "redefine";
            local *Term::Clear::_get_clear_str = sub { "I am calculated $$" };
            trap { Term::Clear::clear() };
            is $trap->stdout, "I am cached $$";
        };

        it "should do system call if Term::Cap can’t be loaded";
        it "should try to do POSIX if POSIX was enabled";
        it "should try to do POSIX if POSIX.pm is loade";
        it "should use Term::Cap’s result";
        it "should do system call if Term::Cap’s result is empty";
    };
};

runtests unless caller;
