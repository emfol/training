
var app = {
  msgs: [ "String #1...", "String #2...", "String #3...", null ],
  payload: function ( msg ) {
    if ( typeof msg !== "string" ) {
      msg = "Default String...";
    }
    console.log( "Msg: " + msg );
  },
  tick: function () {
    if ( app.msgs.length > 0 ) {
      app.payload( app.msgs.shift() );
      setTimeout( app.tick, 1000 );
      return;
    }
    console.log( "Tick: Done!" );
  }
};

console.log( "App: Init..." );
app.tick();
console.log( "App: Done!" );

