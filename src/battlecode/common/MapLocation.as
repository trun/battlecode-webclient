package battlecode.common {

    public class MapLocation {

        private var x:uint;
        private var y:uint;

        public function MapLocation(x:uint, y:uint) {
            this.x = x;
            this.y = y;
        }

        public function getX():uint {
            return x;
        }

        public function getY():uint {
            return y;
        }

        public function add(dir:Direction):MapLocation {
            switch (dir) {
                case Direction.NORTH_EAST:
                    return new MapLocation(x + 1, y - 1);
                case Direction.NORTH_WEST:
                    return new MapLocation(x - 1, y - 1);
                case Direction.SOUTH_EAST:
                    return new MapLocation(x + 1, y + 1);
                case Direction.SOUTH_WEST:
                    return new MapLocation(x - 1, y + 1);
                case Direction.NORTH:
                    return new MapLocation(x, y - 1);
                case Direction.SOUTH:
                    return new MapLocation(x, y + 1);
                case Direction.EAST:
                    return new MapLocation(x + 1, y);
                case Direction.WEST:
                    return new MapLocation(x - 1, y);
                default:
                    return new MapLocation(x, y);
            }
        }

        public function directionTo(loc:MapLocation):String {
            var dx:int = loc.x - this.x;
            var dy:int = loc.y - this.y;

            if (Math.abs(dx) >= 2.414 * Math.abs(dy)) {
                if (dx > 0) {
                    return Direction.EAST;
                } else if (dx < 0) {
                    return Direction.WEST;
                } else {
                    return Direction.OMNI;
                }
            } else if (Math.abs(dy) >= 2.414 * Math.abs(dx)) {
                if (dy > 0) {
                    return Direction.SOUTH;
                } else {
                    return Direction.NORTH;
                }
            } else {
                if (dy > 0) {
                    if (dx > 0) {
                        return Direction.SOUTH_EAST;
                    } else {
                        return Direction.SOUTH_WEST;
                    }
                } else {
                    if (dx > 0) {
                        return Direction.NORTH_EAST;
                    } else {
                        return Direction.NORTH_WEST;
                    }
                }
            }
        }

        public function equals(o:MapLocation):Boolean {
            return x == o.x && y == o.y;
        }

        public function toString():String {
            return x + "," + y;
        }

    }

}