import click

@click.group()
def cli():
    pass

# or @cli.command()
@click.command()
def init():
    click.echo('Initialized the database')

# or @cli.command()
@click.command()
def drop():
    click.echo('Dropped the database')

cli.add_command(init)
cli.add_command(drop)

if __name__ == '__main__':
    cli()
