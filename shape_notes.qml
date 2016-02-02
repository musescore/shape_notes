//=============================================================================
//  MuseScore
//  Music Composition & Notation
//
//  Copyright (C) 2015 Nicolas Froment
//
//  This program is free software; you can redistribute it and/or modify
//  it under the terms of the GNU General Public License version 2
//  as published by the Free Software Foundation and appearing in
//  the file LICENCE.GPL
//=============================================================================

import QtQuick 2.2
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import MuseScore 1.0

MuseScore {
      version:  "1.0"
      description: "Change notehead according to pitch. Sacred harp, shape notes, Aikin."
      menuPath: "Plugins.Notes.Shapes Notes"
      pluginType: "dialog"

      id: window
      width: 220
      height: 130
      ExclusiveGroup { id: exclusiveGroup }
      ColumnLayout {
        id: column
        anchors.margins : 10
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        CheckBox {
          id: shape7CheckBox
          text: "7 shape notes"
          checked: true
          exclusiveGroup: exclusiveGroup
        }
        CheckBox {
          id: shape4CheckBox
          text: "4 shape notes"
          exclusiveGroup: exclusiveGroup
        }
        CheckBox {
          id: normalCheckBox
          text: "Normal notes"
          exclusiveGroup: exclusiveGroup
        }
      }
      RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: column.bottom
            height: 70
            Button {
              id: okButton
              text: "Ok"
              onClicked: {
                apply()
                Qt.quit()
              }
            }
            Button {
              id: closeButton
              text: "Close"
              onClicked: { Qt.quit() }
            }

        }


      //                          -7   -6   -5   -4   -3   -2   -1    0    1    2    3    4    5    6    7
      property variant scales :  ['C', 'G', 'D', 'A', 'E', 'B', 'F', 'C', 'G', 'D', 'A', 'E', 'B', 'F', 'C'];

      // Apply the given function to all notes in selection
      // or, if nothing is selected, in the entire score

      function applyToNotesInSelection(func) {
            var cursor = curScore.newCursor();
            cursor.rewind(1);
            var startStaff;
            var endStaff;
            var endTick;
            var fullScore = false;
            if (!cursor.segment) { // no selection
                  fullScore = true;
                  startStaff = 0; // start with 1st staff
                  endStaff = curScore.nstaves - 1; // and end with last
            } else {
                  startStaff = cursor.staffIdx;
                  cursor.rewind(2);
                  if (cursor.tick == 0) {
                        // this happens when the selection includes
                        // the last measure of the score.
                        // rewind(2) goes behind the last segment (where
                        // there's none) and sets tick=0
                        endTick = curScore.lastSegment.tick + 1;
                  } else {
                        endTick = cursor.tick;
                  }
                  endStaff = cursor.staffIdx;
            }
            console.log(startStaff + " - " + endStaff + " - " + endTick)
            for (var staff = startStaff; staff <= endStaff; staff++) {
                  for (var voice = 0; voice < 4; voice++) {
                        cursor.rewind(1); // sets voice to 0
                        cursor.voice = voice; //voice has to be set after goTo
                        cursor.staffIdx = staff;

                        if (fullScore)
                              cursor.rewind(0) // if no selection, beginning of score

                        while (cursor.segment && (fullScore || cursor.tick < endTick)) {
                              if (cursor.element && cursor.element.type == Element.CHORD) {
                                    var graceChords = cursor.element.graceNotes;
                                    for (var i = 0; i < graceChords.length; i++) {
                                          // iterate through all grace chords
                                          var notes = graceChords[i].notes;
                                          func(note, cursor.keySignature);
                                    }
                                    var notes = cursor.element.notes;
                                    for (var i = 0; i < notes.length; i++) {
                                          var note = notes[i];
                                          func(note, cursor.keySignature);
                                    }
                              }
                              cursor.next();
                        }
                  }
            }
      }

      function shapeNotes(note, curKey) {
        console.log("shapeNotes")
          var tpcNames = "FCGDAEB"
          var name = tpcNames[(note.tpc + 1) % 7]

          var names = "CDEFGAB"
          var scale = scales[curKey+7];
          
          var degrees = [0, 0, 0, 0, 0, 0, 0]; 
          if (shape4CheckBox.checked)
            degrees =[9, 12, 10, 9, 12, 10, 4]; // 4 notes
          else if (shape7CheckBox.checked)
            degrees = [7, 8, 4, 9, 12, 10, 11]; // 7 notes
   
          note.headGroup = degrees[(names.indexOf(name) - names.indexOf(scale) +28)%7];           
      }

      function apply() {
        console.log("hello shapeNotes");
        curScore.startCmd();
        applyToNotesInSelection(shapeNotes);
        curScore.endCmd();
      }

      onRun: {
         if (typeof curScore === 'undefined')
            Qt.quit();
      }
}
