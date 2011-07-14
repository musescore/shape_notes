//=============================================================================
//  Black notes : Paint all notes in black 
//  http://musescore.org/en/project/shape_notes
//
//  Copyright (C)2010 Nicolas Froment (lasconic)
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2.
//
//  This program is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with this program; if not, write to the Free Software
//  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
//=============================================================================

var NOTE_NORMAL = 0;
var NOTE_4 = 1;
var NOTE_7 = 2;

//---------------------------------------------------------
//    init
//    this function will be called on startup of mscore
//---------------------------------------------------------

function init()
      {
      }

//-------------------------------------------------------------------
//    run
//-------------------------------------------------------------------

//            -7   -6   -5   -4   -3   -2   -1   0     1    2    3    4    5    6    7
var scales = ['C', 'G', 'D', 'A', 'E', 'B', 'F', 'C', 'G', 'D', 'A', 'E', 'B', 'F', 'C'];


//---------------------------------------------------------
//    init
//---------------------------------------------------------

function init()
      {
      };

var form;

//---------------------------------------------------------
//    run
//    create gui from qt designer generated file test4.ui
//---------------------------------------------------------

function run()
      {
      var loader = new QUiLoader(null);
      var file   = new QFile(pluginPath + "/shape_notes.ui");
      file.open(QIODevice.OpenMode(QIODevice.ReadOnly, QIODevice.Text));
      form = loader.load(file, null);
      form.buttonBox.accepted.connect(accept);
      form.show();
      };


function accept()
      {
      var idx = -1;
      if (form.normal.checked)
            idx = NOTE_NORMAL;
      else if (form.notes4.checked)
            idx = NOTE_4;
      else if (form.notes7.checked)
            idx = NOTE_7;
      if (idx != -1)
            changeShape(idx);
      }

function changeShape(idx)
      {
      var names = "CDEFGAB"
      var curKey = curScore.keysig;
      var scale = scales[curKey+7];
      
      var degrees = [0, 0, 0, 0, 0, 0, 0]; 
      if (idx == NOTE_4)
        degrees = [9, 12, 10, 9, 12, 10, 4];
      else if (idx == NOTE_7)
        degrees = [7, 8, 4, 9, 12, 10, 11];
        
      var cursor = new Cursor(curScore);
      for (var staff = 0; staff < curScore.staves; ++staff) {
            cursor.staff = staff;
            for (var v = 0; v < 3; v++) {
                  cursor.voice = v;
                  cursor.rewind();  // set cursor to first chord/rest

                  while (!cursor.eos()) {
                        if (cursor.isChord()) {
                              var chord = cursor.chord();
                              var n     = chord.notes;
                              for (var i = 0; i < n; i++) {
                                    var note   = chord.note(i);
                                    var name = note.name.substring(0,1);
                                    
                                    note.noteHead = degrees[(names.indexOf(name) - names.indexOf(scale) +28)%7];
                                    }
                              }
                        cursor.next();
                        }
                  }
            }
      }

var mscorePlugin = {
      menu: 'Plugins.Shape notes',
      init: init,
      run:  run
      };

mscorePlugin;

