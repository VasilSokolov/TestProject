package softuni.demo04052018.task5;

public class Movie {
	private String name, actors;
	private int releaseYr;

	public Movie() {
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public String getActors() {
		return actors;
	}

	public void setActors(String actors) {
		this.actors = actors;
	}

	public int getReleaseYr() {
		return releaseYr;
	}

	public void setReleaseYr(int releaseYr) {
		this.releaseYr = releaseYr;
	}

	@Override
	public int hashCode() {
		return actors.hashCode() + name.hashCode() + releaseYr;
	}

	@Override
	public boolean equals(Object obj) {
		Movie m = (Movie) obj;
		return m.actors.equals(this.actors) && m.name.equals(this.name) && m.releaseYr == this.releaseYr;
	}	
}
