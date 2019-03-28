package condition;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class GearML {

	private Long id;
	private String color;
	private int pin;
	private String email;
	private String fullName;
	private boolean active;
}
