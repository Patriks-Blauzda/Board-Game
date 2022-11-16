public class Player {
    int position = 0;

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
