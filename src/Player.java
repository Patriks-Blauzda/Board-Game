import java.util.Vector;

public class Player {
    boolean isturn = false;
    char playersymbol;

    Vector2 position = new Vector2();

    // Inventory for cards
    Vector inventory = new Vector(5);


    // Rolls dice for player
    public int roll(int n) {
        int sum = 0;

        for(int i = 1; i <= n; i++) {
            int dice = 1 + (int) (Math.random() * (6 - 1));
            sum += dice;

            System.out.printf("\n\n%d. metiens: %d\n", i, dice);
        }
        
        System.out.println();
        System.out.printf("Kopā: %d\n\n", sum);
        return sum;
    }
}
