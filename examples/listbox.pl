#
#  Copyright (c) 1997-2000 The Protein Laboratory, University of Copenhagen
#  All rights reserved.
#
#  Redistribution and use in source and binary forms, with or without
#  modification, are permitted provided that the following conditions
#  are met:
#  1. Redistributions of source code must retain the above copyright
#     notice, this list of conditions and the following disclaimer.
#  2. Redistributions in binary form must reproduce the above copyright
#     notice, this list of conditions and the following disclaimer in the
#     documentation and/or other materials provided with the distribution.
#
#  THIS SOFTWARE IS PROVIDED BY THE AUTHOR AND CONTRIBUTORS ``AS IS'' AND
#  ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
#  IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
#  ARE DISCLAIMED.  IN NO EVENT SHALL THE AUTHOR OR CONTRIBUTORS BE LIABLE
#  FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
#  DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
#  OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
#  HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
#  LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
#  OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
#  SUCH DAMAGE.
#
#  $Id: listbox.pl,v 1.5 2000/10/18 11:58:08 tobez Exp $
#
#  Example of listbox extended usage
#
use strict;
use Prima qw( ComboBox Edit);


package TestWindow;
use vars qw(@ISA);
@ISA = qw(Prima::Window);

sub create_menu
{
   return [
      [ "~ListBox" => [
                  ["~Add text" => "AddItem"],
                  ["~Delete current" => sub{$_[0]-> ListBox1-> delete_items( $_[0]-> ListBox1-> focusedItem);}],
                  ["Delete a~ll" => sub{$_[0]-> ListBox1-> delete_items(0..$_[0]-> ListBox1-> count )}],
                  [],
                  ["~Print all" => "PrintAll"],
                  ["Print ~selected" => sub{foreach ($_[0]-> ListBox1-> selectedItems){print "$_\n"};}],
                  ["Print ~focused" => sub{ print $_[0]-> ListBox1-> focusedItem."\n";}],
                  [],
                  ["Toggle ~extended selection"=> sub{$_[0]->ListBox1-> extendedSelect(!$_[0]->ListBox1-> extendedSelect)}],
                  ["Toggle ~multiple selection"=> sub{$_[0]->ListBox1-> multiSelect(!$_[0]->ListBox1-> multiSelect)}],
                  ["~Increase item height"=>sub{$_[0]->ListBox1->itemHeight($_[0]->ListBox1->itemHeight+2)}],
                  ["~Decrease item height"=>sub{$_[0]->ListBox1->itemHeight($_[0]->ListBox1->itemHeight-2)}],
                  [],
                  ["Add~itional"=> sub
                     {
                        my $box  = $_[0]-> ListBox1;
                        $box-> add_items( 'Hello', 'user', 'from', 'Perl');
                     }
                  ]
                ]],
     [
       "~Edit" => [
                  ["~VScroll" => sub{$_[0]->Edit1->vScroll(!$_[0]->Edit1->vScroll)}],
                  ["~HScroll" => sub{$_[0]->Edit1->hScroll(!$_[0]->Edit1->hScroll)}],
                  ["B~oth" => sub{
                     $_[0]->Edit1->set( hScroll => !$_[0]->Edit1->hScroll,
                                        vScroll => !$_[0]->Edit1->vScroll)
                   }],
                  ["~Border" => sub{$_[0]->Edit1->borderWidth(!$_[0]->Edit1->borderWidth)}],
     ]],
     [ "~ComboBox" => [
            ["~Add text" => "AddItemC"],
            ["Delete a~ll" => sub{$_[0]-> ComboBox1-> List-> delete_items( 0..$_[0]-> ComboBox1-> List-> count) }],
            ["Print ~text" => sub{ print $_[0]-> ComboBox1-> text."\n";}],
            [],
            ["~Set style" => [
                 [ "~Simple" => sub {$_[0]->ComboBox1->style(cs::Simple)}],
                 [ "~Drop down" => sub {$_[0]->ComboBox1->style(cs::DropDown)}],
                 [ "Drop down ~list" => sub {$_[0]->ComboBox1->style(cs::DropDownList)}],
              ]],
            [],
            ["Add~itional"=> sub
               {
                  my $box  = $_[0]-> ComboBox1-> List;
                  $box-> add_items( 'Hello', 'user', 'from', 'Perl');
               }
            ]
       ]],
   ];
}


sub AddItem
{
  my $self = shift;
  $self-> ListBox1-> add_items( $self->InputLine1-> text);
}

sub AddItemC
{
  my $self = shift;
  $self-> ComboBox1-> List-> add_items( $self->InputLine1-> text);
}


sub PrintAll
{
  my $self = shift;
  print( "$_\n") for @{$self-> ListBox1-> items};
}


package UserInit;
$::application = Prima::Application->create( name => "listbox.pm");
my $w = TestWindow->create(
   name    =>  "Window1",
   origin  => [ 100, 100],
   size    => [ 600, 230],
   text => "List & edit boxes example",
   menuItems => TestWindow::create_menu,
   onDestroy => sub { $::application-> close},
);

$w-> insert("InputLine",
   origin => [ 50, 20],
   width  => 250,
   name   => 'InputLine1',
);

$w-> insert( "ListBox",
   origin         => [220, 74],
   size           => [160, 126],
   hScroll        => 1,
   multiSelect    => 0,
   extendedSelect => 1,
   #integralHeight => 1,
   tabStop         =>1,
   name            => 'ListBox1',
   font => { size => 24},
   items          => ['Items', 'created', 'indirect'],
);
$w-> insert( "Edit",
   origin         => [20, 74],
   size           => [160, 126],
   maxLen         => 200,
   name           => 'Edit1',
   hScroll        => 1,
   wantReturns    => 0,
);
$w-> insert( "ComboBox",
   origin         => [400, 74],
   size           => [160, 126],
   name           => 'ComboBox1',
   items          => ['Combo', 'box', 'salutes', 'you!'],
);

run Prima;
