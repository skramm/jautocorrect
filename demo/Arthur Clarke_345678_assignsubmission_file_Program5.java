public class Program5
{
	public static void main( String[] args )
	{
		if( args.length == 0 )
		{
			System.out.println("missings args");
			System.exit(1);
		}
		double v = Double.parseDouble(args[1]);
		
		if(args[0].equals("p") )
			System.out.println(v*v);
		else
		{
			if(args[0].equals("S") )
				System.out.println(v+v);
			else
				System.out.println("invalid arguments");
		 }
	}
}
