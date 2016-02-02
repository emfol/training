
var diskPart = require( './diskpart' ),
    p, k = diskPart.units,
    disk = {
        sectorCount: 976773168,
        gapSize: 4 * k.MiB
    },
    part = {
        linux: {
            boot: 1 * k.GiB,
            root: 64 * k.GiB,
            data: 256 * k.GiB,
            swap: 3 * k.GiB
        }
    };

var total = 4 + 1024 + 4 + ( 64 * 1024 ) + 4 + ( 256 * 1024 ) + 4 + ( 3 * 1024 ) + 4;

disk = new diskPart.Disk( disk );
for ( p in part.linux ) {
    part.linux[ p ] = new diskPart.Partition( part.linux[ p ] );
}

module.exports = {
    diskPart: diskPart,
    disk: disk,
    part: part,
    temp: total
};

