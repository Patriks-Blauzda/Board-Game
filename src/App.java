public class App {

    static Player player = new Player();


    static int[][] map = {
        {1, 0, 2, 2, 2, 2, 2, 2, 0, 0},
        {2, 0, 2, 0, 0, 0, 0, 2, 0, 0},
        {2, 0, 2, 0, 0, 0, 0, 2, 0, 0},
        {2, 2, 2, 0, 0, 0, 0, 2, 0, 0},
        {0, 0, 0, 0, 0, 0, 0, 2, 0, 0},
        {0, 2, 2, 2, 0, 0, 0, 2, 0, 0},
        {0, 2, 0, 2, 2, 2, 2, 2, 0, 0},
        {0, 2, 0, 0, 0, 0, 0, 0, 0, 0},
        {0, 2, 0, 0, 0, 0, 0, 0, 0, 0},
        {0, 2, 2, 2, 2, 2, 2, 2, 2, 3}
    };

    // draws the board based on the variable above

    /*
    * 0: tukšs
    * 1: sākums
    * 2: celiņš
    * 3: beigas
    */
    public static void draw() {
        System.out.flush();
        
        
        for(int y = 0; y < map.length; y++) {
            for(int x = 0; x < map[y].length; x++) {

                String tile = "   "; 

                if(player.position.x == x && player.position.y == y) {
                    tile = "[P]";
                } else {
                    switch(map[y][x]) {
                        case 1: tile = "[S]"; break;
                        case 2: tile = "[ ]"; break;
                        case 3: tile = "[B]"; break;
                        default: tile = "   ";
                    }
                }

                System.out.print(tile);
            }
            System.out.println();
        }
    }


    public static void main(String[] args) throws Exception {
        player.position.x += 2;
        draw();
    }
}
