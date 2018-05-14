package testable.code;

public class MemoryLayoutPresenter implements IPresenterBase {
	
	public static void main(String[] args) {		

	}	
	
	@SuppressWarnings("unused")
	private IViewBase view;

	@Override
	public void MemoryLayoutPresenter(IViewBase myView) {
		this.view = myView;
	}
}

class Runner{
	
}