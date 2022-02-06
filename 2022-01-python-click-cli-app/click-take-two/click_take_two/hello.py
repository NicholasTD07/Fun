import click

@click.command()
@click.option('--count', default=1, help='Number of greetings')
@click.option('--name', prompt='Your Name', help='Kimi no Na wa.')
def hello(count, name):
    """君の名は --- A simple program that greets NAME for a total of COUNT times."""
    for _ in range(count):
        click.echo(f"Hello {name}!")

if __name__ == '__main__':
    hello()
