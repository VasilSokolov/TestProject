package condition;

public class GearServiceIml implements GearService {
	GearCl g;
	GearML ml;
	@Override
	public GearCl getGear() {
		return this.g;
	}

	@Override
	public void setGear(GearCl gear) {
		this.g = gear;
	}

	@Override
	public GearML getGearMl() {
		return this.ml;
	}

	@Override
	public void createGearMl(GearML ml) {
		this.ml = ml;
	}

}
