
module.exports = ( function () {

    var KiB = 1024,
        MiB = 1024 * KiB,
        GiB = 1024 * MiB;

    var utils = {
        fit: function ( amount, unit ) {
            var diff = amount % unit,
                count = ( amount - diff ) / unit;
            return ( count + ( diff !== 0 ? 1 : 0 ) );
        }
    };

    /*
     * Disk
     */

    function Disk( settings ) {

        var field, objRef = this;

        objRef.sectorSize = 512;
        objRef.sectorCount = 0;
        objRef.optimalIOSize = 4096;
        objRef.optimalBlockSize = 1 * MiB;
        objRef.gapSize = 1 * MiB;
        objRef.partitions = [];

        if ( typeof settings === 'object' && settings !== null ) {
            for ( field in settings ) {
                if ( field in objRef ) {
                    objRef[ field ] = settings[ field ];
                }
            }
        }

    }

    Disk.prototype = new Disk();

    Disk.prototype.isValid = function () {

        if ( this.sectorSize < 1 || this.sectorCount < 1 )
            return false;

        if ( this.optimalIOSize < this.sectorSize ||
            ( this.optimalIOSize % this.sectorSize ) !== 0 )
            return false;

        if ( this.optimalBlockSize < this.optimalIOSize ||
            ( this.optimalBlockSize % this.optimalIOSize ) !== 0 )
            return false;

        if ( this.gapSize < this.optimalBlockSize ||
            ( this.gapSize % this.optimalBlockSize ) !== 0 )
            return false;

        return true;

    };

    Disk.prototype.addPartition = function ( partition ) {

        if ( !this.isValid() || !( partition instanceof Partition ) )
            return -1;

        partition.setDisk( this );
        if ( partition.isValid() )
            return -2;

        this.partitions.push( partition );
        return 0;

    };

    Disk.prototype.getSectorCountForOptimalIO = function () {
        return ( this.optimalIOSize / this.sectorSize );
    };

    Disk.prototype.getSectorCountForOptimalBlock = function () {
        return ( this.optimalBlockSize / this.sectorSize );
    };

    Disk.prototype.getOptimalBlockCount = function () {
        var unit = this.getSectorCountForOptimalBlock(),
            amount = this.sectorCount,
            diff = amount % unit;
        return ( ( amount - diff ) / unit );
    };

    Disk.prototype.getSectorSpill = function () {
        return ( this.sectorCount % this.getSectorCountForOptimalBlock() );
    };

    Disk.prototype.getTotalSize = function () {
        return ( this.sectorCount * this.sectorSize );
    };

    /*
     * Partition
     */

    function Partition( intendedSize ) {
        this.intendedSize = intendedSize;
        this.partitions = [];
        this.disk = null;
    }

    Partition.prototype = new Partition( 0 );

    Partition.prototype.isValid = function () {

        var i, p, l;

        if ( !( this.disk instanceof Disk ) || !this.disk.isValid() )
            return false;

        if ( ( i = ( l = this.partitions ).length ) > 0 ) {
            while ( i > 0 ) {
                i--;
                p = l[i];
                if ( !( p instanceof Partition ) || !p.isValid() )
                    return false;
            }
        } else if ( this.intendedSize < 1 ) {
            return false;
        }

        return true;

    };

    Partition.prototype.getSectorCount = function () {
        return utils.fit( this.intendedSize, this.disk.sectorSize );
    };

    Partition.prototype.getOptimalIOBlockCount = function () {
        return utils.fit( this.intendedSize, this.disk.optimalIOSize );
    };

    Partition.prototype.getOptimalBlockCount = function () {
        return utils.fit( this.intendedSize, this.disk.optimalBlockSize );
    };

    Partition.prototype.getSectorCountForOptimalIOBlocks = function () {
        return this.getOptimalIOBlockCount() * this.disk.getSectorCountForOptimalIO();
    };

    Partition.prototype.getSectorCountForOptimalBlocks = function () {
        return this.getOptimalBlockCount() * this.disk.getSectorCountForOptimalBlock();
    };


    /*
     * Interface
     */

    return {
        units: { KiB: KiB, MiB: MiB, GiB: GiB },
        Disk: Disk,
        Partition: Partition
    }

} )();

