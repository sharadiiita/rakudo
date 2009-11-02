## $Id$

=head1 TITLE

Code - Perl 6 Code class

=head1 DESCRIPTION

This file sets up the Perl 6 C<Code> class, the base class
for executable objects.

=cut

.namespace ['Code']

.sub 'onload' :anon :load :init
    .local pmc p6meta, codeproto
    p6meta = get_hll_global ['Perl6Object'], '$!P6META'
    codeproto = p6meta.'new_class'('Code', 'parent'=>'Any', 'attr'=>'$!do $!name')
    $P0 = get_hll_global 'Callable'
    $P0 = $P0.'!select'()
    p6meta.'add_role'($P0, 'to'=>codeproto)
    $P1 = new ['Role']
    $P1.'name'('invokable')
    p6meta.'add_role'($P1, 'to'=>codeproto)
    p6meta.'register'('Sub', 'parent'=>codeproto, 'protoobject'=>codeproto)
.end


=item new(name, do)

=cut

.sub 'new' :method
    .param pmc name
    .param pmc do
    $P0 = self.'HOW'()
    $P0 = getprop 'parrotclass', $P0
    $P0 = new $P0
    setattribute $P0, '$!name', name
    setattribute $P0, '$!do', do
    .return ($P0)
.end


=item assumming()

Returns a curried version of self.

=cut

.sub 'assuming' :method :subid('assuming')
    .param pmc args :slurpy
    .param pmc named_args :slurpy :named
    .local pmc curried
    .lex '@args', args
    .lex '%args', named_args
    .lex '$obj', self
    .const 'Sub' curried = 'assuming_helper'
    capture_lex curried
    .return (curried)
.end

.sub 'assuming_helper' :outer('assuming')
    .param pmc args :slurpy
    .param pmc named_args :slurpy :named
    .local pmc obj, assumed_args, assumed_named_args, result
    find_lex obj, '$obj'
    find_lex assumed_args, '@args'
    find_lex assumed_named_args, '%args'
    result = obj(assumed_args :flat, args :flat, assumed_named_args :flat :named, named_args :flat :named)
    .return (result)
.end


=item callwith(...)

Just calls this block with the supplied parameters.

=cut

.sub 'callwith' :method :vtable('invoke')
    .param pmc pos_args    :slurpy
    .param pmc named_args  :slurpy :named
    $P0 = getattribute self, '$!do'
    .tailcall $P0(pos_args :flat, named_args :flat :named)
.end


=item multi

=cut

.sub 'multi' :method
    $P0 = get_hll_global ['Bool'], 'False'
    .return ($P0)
.end


=item name

=cut

.sub 'name' :method
    $P0 = getattribute self, '$!name'
    $S0 = $P0
    .return ($S0)
.end


=item perl()

Return a response to .perl.

=cut

.namespace ['Code']
.sub 'perl' :method
    .return ('{ ... }')
.end

=item signature()

Gets the signature for the block, or returns Failure if it lacks one.

=cut

.sub 'signature' :method
    $P0 = getattribute self, '$!do'
    $P0 = getprop '$!signature', $P0
    if null $P0 goto no_sig
    $P1 = get_hll_global 'Signature'
    $P1 = $P1.'new'('ll_sig' => $P0)
    .return ($P1)
  no_sig:
    .tailcall '!FAIL'('No signature found')
.end


=back

=cut

# Local Variables:
#   mode: pir
#   fill-column: 100
# End:
# vim: expandtab shiftwidth=4 ft=pir:
