package lambda.streams;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.Collections;
import java.util.HashMap;
import java.util.HashSet;
import java.util.List;
import java.util.Map;
import java.util.logging.Logger;
import java.util.stream.Collectors;

import lambda.model.InstallmentTable;
import lambda.model.LoanApplication;
import lambda.model.LoanApplicationService;
import lambda.model.Person;
import lambda.model.Product;
import lambda.model.Users;

public class StreamsDemo {

	private static final Logger logger = Logger.getLogger("StreamsDemo");
	
	public static void main(String[] args) {
		StreamsDemo demo = new StreamsDemo();

//		demo.items();
//		List<Users> addData = demo.addData();
//		System.out.println(addData.toString());
		boolean isPassed = demo.passedCheck();
//		System.out.println("Sign: " + isPassed);
//		logger.info("Result");
//		log.error("CxmService call sendClientProfile method : "); 
//		demo.addDataInList();
//		demo.countFee();
	}

	private List<String> items() {
		List<String> items = new ArrayList<>();
		items.add("A");
		items.add("B");
		items.add("C");
		items.add("D");
		items.add("E");

		System.out.println("----------LIST---------");
		// lambda
		// Output : A,B,C,D,E
		items.forEach(item -> System.out.print(item));
		System.out.println();
		// Output : C
		items.forEach(item -> {
			item = "C".equals(item) ? item : "";
			System.out.print(item);
		});
		items.add("V");

		System.out.println(items.add("V"));
		// method reference
		// Output : A,B,C,D,E
		items.forEach(System.out::print);

		System.out.println();
		// Stream and filter
		// Output : B
		items.stream().filter(s -> s.contains("B")).forEach(System.out::print);
		System.out.println();
		System.out.println("----------MAP---------");
		Map<String, Integer> mapItems = new HashMap<>();
		mapItems.put("A", 10);
		mapItems.put("B", 20);
		mapItems.put("C", 30);
		mapItems.put("D", 40);
		mapItems.put("E", 50);
		mapItems.put("F", 60);

		mapItems.forEach((k, v) -> System.out.println("Item : " + k + " Count : " + v));

		mapItems.forEach((k, v) -> {
			System.out.println("Item : " + k + " Count : " + v);
			if ("E".equals(k)) {
				System.out.println("Hello E");
			}
		});

		return items;
	}

	private void lambda() {

		NumericTest isEven = (int n) -> (n % 2) == 0;
		NumericTest isNegative = (int n) -> n < 0;

		StringsTest morningGreeting = (String str) -> "Good Morning " + str + "!";

		// Output: false
		System.out.println(isEven.computeTest(5));

		// Output: true
		System.out.println(isNegative.computeTest(-5));
	}

	private List<Users> getData() {
		List<Product> products = new ArrayList<>(
				Arrays.asList(new Product(1L, "Ajay", new BigDecimal(355.54).setScale(2, RoundingMode.CEILING)),
						new Product(113L, "Ajay", new BigDecimal(3534).setScale(2, RoundingMode.CEILING)),
						new Product(3l, "Ajay", new BigDecimal(3533.2).setScale(2, RoundingMode.CEILING)),
						new Product(4L, "Ajay", new BigDecimal(123.4).setScale(2, RoundingMode.CEILING)),
						new Product(5L, "Ajay", new BigDecimal(55.2).setScale(2, RoundingMode.CEILING))));

		List<Users> userses = new ArrayList<>(Arrays.asList(new Users(123L, "ssay", "Accounting", products),
				new Users(12L, "Ajay", "Accounting", products), new Users(13L, "Aj2", "Accounting", products),
				new Users(14L, "A1y", "Accounting", products), new Users(153L, "A2y", "Accounting", products)));
		userses.add(new Users(77L, "A2y", "Accounting", products));
		int count = 0;

		for (Users user : userses) {
			List<Product> p = user.getProducts();
			System.out.println(user.toString());
			for (Product product : p) {
				System.out.println(product.toString() + " " + count++);
			}
		}
		new Users();

		return userses;
	}

	private List<Users> addData() {
		List<String> lines = new ArrayList<>(Arrays.asList("spring", "node", "mkyong"));
		List<String> result = getFilterOutput(lines, "mkyong");
		for (String temp : result) {
			System.out.println(temp); // output : spring, node
		}

		List<Users> users = lines.stream()
				.map(element -> new Users(1l, element, element,
						Arrays.asList(
								new Product(2l, element, new BigDecimal(355.54).setScale(2, RoundingMode.CEILING)))))
				.collect(Collectors.toList());
		System.out.println();
		System.out.println(users.toString());
		return users;
	}

	private static List<String> getFilterOutput(List<String> lines, String filter) {
		List<String> result = new ArrayList<>();
//         for (String line : lines) {
//             if (!"mkyong".equals(line)) { // we dont like mkyong
//                 result.add(line);
//             }
//         }

		result = lines.stream().filter(line -> filter.equals(line)).collect(Collectors.toList());
		System.out.println(result.toString());
		return result;
	}

	public boolean passedCheck() {
		LoanApplicationService loanAppService = new LoanApplicationService();

//		List<LoanApplication> allActiveLoans = Collections.emptyList();
		List<LoanApplication> allActiveLoans;
		List<LoanApplication> activeLoans;
		List<LoanApplication> accountMailDTOS;
		
		
		List<String> bankAccounts = loanAppService.getAllClients().stream().filter(c -> c.isActive() && c.isAgreementSigned()).map(c->c.getClientPin()).collect(Collectors.toList());
		List<String> emails = loanAppService.getIncEmails().stream().map(email-> email.getIncludedEmails()).flatMap(group -> group.stream()).collect(Collectors.toList());  

		logger.info(emails.toString());
		allActiveLoans = loanAppService.getAllClients().stream().filter(a -> a.isActive())
				.collect(Collectors.toList());

		activeLoans = allActiveLoans.stream().filter(a -> a.isAgreementSigned()).collect(Collectors.toList());

		if (activeLoans.isEmpty()) {
			return true;
		}

		Boolean isPassedChack = activeLoans.size() <= 2;

		logger.info(isPassedChack.toString());
		return isPassedChack;
	}
	//TODO Example of nested loops
//	matrix3.stream().filter(row -> !row.isEmpty()).flatMap(row -> row.stream())
//    .filter(col -> !col.isEmpty())
//    .flatMap(col -> col.stream())
//    .filter(cell -> !cell.isEmpty())
//    .flatMap(cell -> cell.stream())
//    .filter(element -> !element.isEmpty())
//    .map(element -> element.substring(0, 1))
//    .forEach(element -> {
//        System.out.print(element);
//    });

	public void addDataInList() {
		Collection<Person> originalPeople = new HashSet<>();
		Collection<Person> newPeople = new HashSet<>();

		originalPeople.add(new Person("William", "Tyndale"));
		originalPeople.add(new Person("Jonathan", "Edwards"));
		originalPeople.add(new Person("Martin", "Luther"));

		newPeople.add(new Person("Jonathan", "Edwards"));
		newPeople.add(new Person("James", "Tyndale"));
		newPeople.add(new Person("Roger", "Moore"));
		
		

		getPersonInList(newPeople, originalPeople);
	}

	private Collection<Person> getPersonInList(final Collection<Person> newPeople, Collection<Person> originalPeople) {
		Collection<Person> list = new ArrayList<>();

		originalPeople.stream()
				.filter(p -> !newPeople.contains(p))
				.forEach(list::add);
		
//				.findFirst()
//				.orElse(null);
//				.forEach(v -> list.add(v));
		
		list.forEach(o -> System.out.printf("%s %s is not in the new list!%n", o.getFirstName(), o.getLastName()));
		System.out.println("---------------------");
		for (Person original : originalPeople) {
			if (!newPeople.contains(original)) {
				System.out.printf("%s %s is not in the new list!%n", original.getFirstName(), original.getLastName());
			}
		}
		
		return list;
	}
	
	private List<InstallmentTable> listInstalmentTable() {
		List<InstallmentTable> list = new ArrayList<>();
		list.add(new InstallmentTable(750d, true));
		list.add(new InstallmentTable(250d, true));
		list.add(new InstallmentTable(350d, true));
		list.add(new InstallmentTable(150d, true));
		list.add(new InstallmentTable(0d, true));
		list.add(new InstallmentTable(50d, false));
		list.add(new InstallmentTable(250d, false));
		
		return list;
	}
	
	private void countFee() {
		List<InstallmentTable> listInstalmentTable = listInstalmentTable();
		long count = listInstalmentTable.stream().filter(i -> i.isSuspended() && i.getNotPaid() > 0).count();

        Double result = 0.1 * count;

		logger.info(result.toString());
	}

}
